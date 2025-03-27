--ＳＮｏ．３７ スパイダー・シャーク
--Number S37: Spider Shark
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 5 WATER monsters, or 1 "Number 37: Hope Woven Dragon Spider Shark"
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),5,3,s.ovfilter,aux.Stringid(id,0))
	--Banish 1 opponent's monster until their next Standby Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.Detach(1,1))
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={37279508} --"Number 37: Hope Woven Dragon Spider Shark"
s.xyz_number=37
function s.ovfilter(c,tp,lc)
	return c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,37279508) and c:IsFaceup()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_STANDBY,id,e,tp,aux.DefaultFieldReturnOp,function() return Duel.IsTurnPlayer(1-tp) end) then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g==0 then return end
		local c=e:GetHandler()
		for atkc in g:Iter() do
			--It loses 1000 ATK until the end of this turn
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			atkc:RegisterEffect(e1)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetTurnID()==Duel.GetTurnCount() and c:IsXyzSummoned() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end