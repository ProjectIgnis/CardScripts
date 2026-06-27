--闇の眼を持つ幻想師・ノー・フェイス
--Dark-Eyes Illusionist Faceless Mage
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this card battles a monster, neither can be destroyed by that battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indestg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--You can discard this card, then activate 1 of these effects (but you can only use each of these effects of "Dark-Eyes Illusionist Faceless Mage" once per turn);
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(Cost.SelfDiscard)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_names={100455007,CARD_TOON_WORLD} --"Mind Scan"
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
function s.plfilter(c,tp)
	return c:IsCode(100455007) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.thfilter(c)
	return c:IsMonster() and c:ListsCode(CARD_TOON_WORLD) and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp)
		and not Duel.HasFlagEffect(tp,id)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		and not Duel.HasFlagEffect(tp,id+100)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	elseif op==2 then
		e:GetHandler():CreateEffectRelation(e)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Place 1 "Mind Scan" from your hand or Deck face-up on your field
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if sc then
			Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	elseif op==2 then
		local c=e:GetHandler()
		local exc=c:IsRelateToEffect(e) and c or nil
		--● Add 1 other monster from your GY to your hand that mentions "Toon World", then you can Special Summon it, ignoring its Summoning conditions
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,exc):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		if Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and sc:IsCanBeSpecialSummoned(e,0,tp,true,false) then
			Duel.ShuffleHand(tp)
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end