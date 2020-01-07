--太陽の守護者
--Luminous Keeper
--fixed and cleaned up by MLD & Larry126
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,57482479,s.ffilter)
	--token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62543393,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(s.atkcon)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22200403,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.effcon)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_series={0x52}
s.listed_names={511009337}
s.material_setcode=0x52
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x52) and c:IsAttribute(ATTRIBUTE_LIGHT,fc,sumtype,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511009337,0,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511009337,0,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,511009337)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,511009337)
end
function s.cfilter(c,tp,r,re,rp)
	if not c:IsCode(511009337) or c:GetPreviousControler()~=tp then return false end
	if r&REASON_EFFECT~=0 then
		return rp~=tp and re and re:IsActiveType(TYPE_MONSTER)
	else
		return c:GetReasonCard() and c:GetReasonCard():IsControler(1-tp)
	end
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,r,re,rp)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local g=eg:Filter(s.cfilter,nil,tp,r,re,rp)
		if chkc:IsControler(tp) then return false end
		if r&REASON_EFFECT~=0 then return re:GetHandler()==chkc
		else return chkc==g:GetFirst():GetReasonCard() end
	end
	local g=eg:Filter(s.cfilter,nil,tp,r,re,rp)
	if chk==0 then
		if r&REASON_EFFECT~=0 then return re:GetHandler():IsControler(1-tp) and re:GetHandler():IsOnField() and re:GetHandler():IsCanBeEffectTarget(e) and re:GetHandler():GetAttack()>800
		else local tc=g:GetFirst():GetReasonCard() return tc:IsControler(1-tp) and tc:IsOnField() and tc:IsCanBeEffectTarget(e) and tc:GetAttack()>800 end
	end
	local tc
	if r&REASON_EFFECT~=0 then tc=re:GetHandler() else tc=g:GetFirst():GetReasonCard() end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:UpdateAttack(-800,nil,e:GetHandler())==-800 then
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
