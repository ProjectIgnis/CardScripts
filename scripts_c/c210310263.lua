--Unexpected Dai-Sojo
--AlphaKretin
function c210310263.initial_effect(c)
	--to defense
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41090784,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c210310263.potg)
	e1:SetOperation(c210310263.poop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetTarget(c210310263.indtg)
	e3:SetValue(c210310263.indval)
	c:RegisterEffect(e3)
end
function c210310263.potg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function c210310263.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
function c210310263.indtg(e,c)
	return (not c:IsType(TYPE_EFFECT) and c:IsLevelBelow(4)) or c:IsSetCard(0xf36)
end
function c210310263.indval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end