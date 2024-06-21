--Ｃ・ダークマター・ワイバーン
--Contact Dark Matter Wyvern
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Check if it tributed a face-down monster for its tribute summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160018006} --Dark Matter Dragon
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	if g:IsExists(Card.IsFacedown,1,nil) then flag=1 end
	e:SetLabel(flag)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) and e:GetLabelObject():GetLabel()~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsCode(160018006) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	--Special Summon
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local ssg=sg:Select(tp,1,1,nil)
		if #ssg>0 then
			Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
