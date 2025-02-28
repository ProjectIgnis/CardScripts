--青春の交換日記
--Exchanging Notes
local s,id=GetID()
local SET_GUTSMASTER=0x526
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GUTSMASTER),tp,LOCATION_MZONE,0,1,nil) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GUTSMASTER}
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	if Duel.Draw(tp,2,REASON_EFFECT)~=2 then return end
	local sg=nil
	local g=Duel.GetOperatedGroup()
	if Duel.SendtoHand(g,1-tp,REASON_EFFECT)>0 then
		Duel.ShuffleHand(1-tp)
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		Duel.BreakEffect()
		Duel.ConfirmCards(tp,hg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		sg=hg:Select(tp,2,2,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
			Duel.ShuffleHand(tp)
		end
	end
	local c=e:GetHandler()
	local exch_g=g+sg
	local mon_g=exch_g:Filter(Card.IsMonster,nil)
	if #mon_g>0 then
		for tc in mon_g:Iter() do
			--If a monster(s) was exchanged by this effect, they cannot be Normal or Special Summoned
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_SUMMON)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			tc:RegisterEffect(e2)
		end
		--Skip this turn's Battle Phase
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_SKIP_BP)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,Duel.GetTurnPlayer())
	end
	if #exch_g>0 then
		--Cards exchanged by this effect are returned to their owner's hand during the End Phase of this turn
		aux.DelayedOperation(exch_g,PHASE_END,id,e,tp,s.thop,nil,nil,nil,aux.Stringid(id,2))
	end
end
function s.thop(ag)
	local turn_player=Duel.GetTurnPlayer()
	local ag1,ag2=ag:Split(Card.IsOwner,nil,turn_player)
	if #ag1>0 then
		Duel.SendtoHand(ag1,turn_player,REASON_EFFECT)
	end
	if #ag2>0 then
		Duel.SendtoHand(ag2,1-turn_player,REASON_EFFECT)
	end
end