--ヴォルカニック・リムファイア
--Volcanic Rimfire
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_VOLCANIC,SET_BLAZE_ACCELERATOR}
s.listed_names={id}
function s.tgfilter(c)
	return c:IsSetCard(SET_VOLCANIC) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.rmfilter(c,tp,ft)
	return (ft>0 or c:IsLocation(LOCATION_STZONE)) and c:IsSetCard(SET_BLAZE_ACCELERATOR) and c:IsAbleToRemove() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp)
end
function s.plfilter(c,tp)
	return c:IsSetCard(SET_BLAZE_ACCELERATOR) and c:IsContinuousSpellTrap() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local b1=not Duel.HasFlagEffect(tp,id) and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil,tp,ft)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD|LOCATION_GRAVE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Banish this card, and if you do, send 1 "Volcanic" monster from your Deck to the GY
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	elseif op==2 then
		--Banish 1 "Blaze Accelerator" card from your field/GY, and if you do, place 1 "Blaze Accelerator" Continuous Spell/Trap from your hand/Deck on your field
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil,tp,ft)
		if #g==0 or Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local plc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		Duel.MoveToField(plc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end