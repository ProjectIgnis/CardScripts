--ＯＴｏＮａＲｉサンダー
--Otonari Thunder
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_THUNDER),tp,LOCATION_MZONE,0,2,nil) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Attach 2 Level 4 LIGHT Thunder monsters, including this card, to 1 Xyz Monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
function s.attachfilter(c,xyzc,tp)
	return c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_THUNDER) and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.xyzfilter(c,tp,ec)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and s.attachfilter(ec,c,tp)
		and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,1,ec,c,tp)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc,tp,c) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsType(TYPE_XYZ)) then return end
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsControler(tp) and s.attachfilter(c,tc,tp)) then return end
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.attachfilter),tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,c,tc,tp)
	if #mg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=mg:Select(tp,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Overlay(tc,g+c,true)
	end
end