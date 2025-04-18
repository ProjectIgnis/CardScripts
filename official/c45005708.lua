--深淵の獣アルベル
--The Bystial Aluber
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--This card's name becomes "Fallen of Albaz" on the field or in the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(CARD_ALBAZ)
	c:RegisterEffect(e1)
	--Take control of or Special Summon 1 Dragon monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_ALBAZ}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.tgfilter(c,e,tp,sc)
	if not (c:IsRace(RACE_DRAGON) and c:IsFaceup()) then return false end
	if c:IsLocation(LOCATION_MZONE) then
		return s.ctrlfilter(c,tp,sc)
	else
		return s.spfilter(c,e,tp,sc)
	end
end
function s.ctrlfilter(c,tp,sc)
	return Duel.GetMZoneCount(tp,sc,tp,LOCATION_REASON_CONTROL)>0 and c:IsAbleToChangeControler()
end
function s.spfilter(c,e,tp,sc)
	return Duel.GetMZoneCount(tp,sc)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local label=e:GetLabel()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and ((label==1 and s.ctrlfilter(chkc,tp,c)) or (label==2 and s.spfilter(chkc,e,tp,c))) end
	if chk==0 then return c:IsAbleToGrave() and Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil,e,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil,e,tp,c):GetFirst()
	if tc:IsLocation(LOCATION_MZONE) then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_TOGRAVE|CATEGORY_CONTROL)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
	else
		e:SetLabel(2)
		e:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE) then
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) then return end
		local label=e:GetLabel()
		if label==1 then
			Duel.GetControl(tc,tp,PHASE_END,1)
		elseif label==2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end