--鬼神 朱沙之王
--Asutraja Susanoo
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuners
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--If this card is Synchro Summoned: You can banish any number of Traps from your GY; banish that many cards on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e)
		return e:GetHandler():IsSynchroSummoned()
	end)
	e1:SetCost(s.bancost)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
	--During the End Phase: You can target up to 2 "Asutra" monsters and/or "Asutra" Traps in your GY and/or banishment; for each of them, add it to your hand or Set it, then if you targeted 2 cards, return this card to the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SET+CATEGORY_LEAVE_GRAVE+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thsettg)
	e2:SetOperation(s.thsetop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ASUTRA}
function s.bancost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsTrap,Card.IsAbleToRemoveAsCost),tp,LOCATION_GRAVE,0,1,nil) end
	local max_banish_count=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsTrap,Card.IsAbleToRemoveAsCost),tp,LOCATION_GRAVE,0,1,max_banish_count,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetChainData().banish_count=#g
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,e:GetChainData().banish_count,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local banish_count=e:GetChainData().banish_count
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g<banish_count then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,banish_count,banish_count,nil)
	if #sg==banish_count then
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.setfilter(c,e,tp,mmz_chk)
	if not (c:IsSetCard(SET_ASUTRA) and c:IsFaceup()) then return end
	if c:IsMonster() then
		return c:IsAbleToHand() or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
	elseif c:IsTrap() then
		return c:IsAbleToHand() or c:IsSSetable()
	end
	return false
end
function s.rescon(to_extra_chk,free_mzones,free_stzones)
	return function(sg,e,tp,mg)
		if #sg==2 and not to_extra_chk then return false end
		local cannot_add_g=sg:Filter(aux.NOT(Card.IsAbleToHand),nil)
		if #cannot_add_g<2 then return true end
		local monsters,traps=cannot_add_g:Split(Card.IsMonster,nil)
		return #monsters<=free_mzones and #traps<=free_stzones
	end
end
function s.thsettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc,e,tp,mmz_chk) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp,mmz_chk) end
	local c=e:GetHandler()
	local to_extra_chk=c:IsAbleToExtra()
	local free_mzones=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local free_stzones=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.GetTargetGroup(s.setfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp,mmz_chk)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon(to_extra_chk,free_mzones,free_stzones),1,tp,aux.Stringid(id,2))
	Duel.SetTargetCard(tg)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SET,tg,#tg,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,tg,#tg,tp,0)
	if tg:IsExists(Card.IsMonster,1,nil) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg:Filter(Card.IsMonster,nil),1,tp,0)
	end
	if tg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE),1,tp,0)
	end
	if #tg==2 then
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,tp,0)
	end
	e:GetChainData().number_of_targets=#tg
end
function s.thsetop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local success=false
	for i=1,#tg do
		local tc=nil
		if #tg==2 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			tc=tg:Select(tp,1,1,nil):GetFirst()
			Duel.HintSelection(tc)
			tg:RemoveCard(tc)
		else
			tc=tg:GetFirst()
			if i==2 then
				Duel.HintSelection(tc)
			end
		end
		local monster_set_chk=tc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		local trap_set_chk=tc:IsTrap() and tc:IsSSetable()
		local success_chk=aux.ToHandOrElse(tc,tp,
			function()
				return monster_set_chk or trap_set_chk
			end,
			function()
				if monster_set_chk then
					if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
						Duel.ConfirmCards(1-tp,tc)
						return true
					end
				elseif trap_set_chk then
					return Duel.SSet(tp,tc)>0
				end
			end,
			aux.Stringid(id,3)
		)
		if tc:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(tp) end
		if not success and success_chk then success=true end
	end
	Duel.SpecialSummonComplete()
	local c=e:GetHandler()
	if success and c:IsRelateToEffect(e) and e:GetChainData().number_of_targets==2 then
		Duel.BreakEffect()
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end