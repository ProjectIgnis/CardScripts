--Ｇゴーレム・スタバン・メンヒル
--G Golem Stubborn Menhir
--scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),2,2)
	c:EnableReviveLimit()
	--Recover or Special Summon 1 EARTH from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
function s.filter(c,e,tp,ft)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsSummonableCard() and (c:IsAbleToHand()
		or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp,ft) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	aux.ToHandOrElse(tc,tp,function(c)
						return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end,
						function(tc)
							if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
								local c=e:GetHandler()
								--Negate its effects
								local e1=Effect.CreateEffect(c)
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetCode(EFFECT_DISABLE)
								e1:SetReset(RESET_EVENT|RESETS_STANDARD)
								tc:RegisterEffect(e1,true)
								local e2=Effect.CreateEffect(c)
								e2:SetType(EFFECT_TYPE_SINGLE)
								e2:SetCode(EFFECT_DISABLE_EFFECT)
								e2:SetReset(RESET_EVENT|RESETS_STANDARD)
								tc:RegisterEffect(e2,true)
								--Banish it if it leaves the field
								local e3=Effect.CreateEffect(c)
								e3:SetDescription(3300)
								e3:SetType(EFFECT_TYPE_SINGLE)
								e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
								e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
								e3:SetReset(RESET_EVENT|RESETS_REDIRECT)
								e3:SetValue(LOCATION_REMOVED)
								tc:RegisterEffect(e3,true)
							end
							Duel.SpecialSummonComplete()
						end,
						aux.Stringid(id,1))
end