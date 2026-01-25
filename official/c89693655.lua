--亜空間バトル
--Subspace Battle
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Apply this effect 3 times, in sequence: ● Each player reveals 1 monster in their Deck, except a monster with ? ATK. Add the monster with higher ATK to the hand of the player that revealed it, also destroy the monster with lower ATK, and if you do, inflict 500 damage to the player that revealed it. If they have the same ATK, shuffle them into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.revealfilter(c)
	return c:IsAttackAbove(0) and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.revealfilter,tp,0,LOCATION_DECK,1,nil)) then return end
	local opp=1-tp
	local tp_codes={}
	local opp_codes={}
	local sc1,sc2,atk1,atk2
	local search_card=nil
	local destroy_card=nil
	local break_chk=false
	for i=1,3 do
		if break_chk then Duel.BreakEffect() end
		break_chk=true
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		sc1=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_CONFIRM)
		sc2=Duel.SelectMatchingCard(opp,s.revealfilter,opp,LOCATION_DECK,0,1,1,nil):GetFirst()
		Duel.ConfirmCards(opp,sc1)
		Duel.ConfirmCards(tp,sc2)
		table.insert(tp_codes,sc1:GetCode())
		table.insert(opp_codes,sc2:GetCode())
		sc1:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		sc2:RegisterFlagEffect(id+1,RESETS_STANDARD_PHASE_END,0,1)
		atk1=sc1:GetAttack()
		atk2=sc2:GetAttack()
		if atk1>atk2 then
			search_card=sc1
			destroy_card=sc2
		elseif atk2>atk1 then
			search_card=sc2
			destroy_card=sc1
		else
			search_card=nil
			destroy_card=nil
			Duel.ShuffleDeck(tp)
			Duel.ShuffleDeck(opp)
		end
		if search_card and destroy_card then
			if Duel.SendtoHand(search_card,nil,REASON_EFFECT)>0 then
				local prev_ctrl=search_card:GetPreviousControler()
				Duel.ConfirmCards(1-prev_ctrl,search_card)
				Duel.ShuffleHand(prev_ctrl)
			else
				Duel.SendtoGrave(search_card,REASON_RULE)
			end
			if Duel.Destroy(destroy_card,REASON_EFFECT)>0 then
				Duel.Damage(destroy_card:GetPreviousControler(),500,REASON_EFFECT)
			end
		end
		if not (Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.revealfilter,tp,0,LOCATION_DECK,1,nil)) then break end
	end
	--Each player cannot activate the effects of the monster they revealed and monsters with the same name as it for the rest of this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re,tp) local rc=re:GetHandler() return re:IsMonsterEffect() and (rc:HasFlagEffect(id) or rc:IsCode(tp_codes)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetValue(function(e,re,tp) local rc=re:GetHandler() return re:IsMonsterEffect() and (rc:HasFlagEffect(id+1) or rc:IsCode(opp_codes)) end)
	Duel.RegisterEffect(e2,opp)
end
