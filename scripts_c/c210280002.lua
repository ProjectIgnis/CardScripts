--Ｅ・ＨＥＲＯ ネオスフィア・ワイズマン
--Elemental HERO Neosphere Wiseman
--concept by Xeno
--script by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,false,false,s.mfilter1,s.mfilter2)
	--SpSummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	--damage&recover
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--piercing
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	--special summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	--activate limit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetOperation(s.aclimit1)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e7:SetCode(EVENT_CHAIN_NEGATED)
	e7:SetRange(LOCATION_MZONE)
	e7:SetOperation(s.aclimit2)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_CANNOT_ACTIVATE)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(0,1)
	e8:SetCondition(s.econ1)
	e8:SetValue(s.elimit)
	c:RegisterEffect(e8)
	--activate limit 2
	local e9=e6:Clone()
	e9:SetOperation(s.aclimit3)
	c:RegisterEffect(e9)
	local e10=e7:Clone()
	e10:SetOperation(s.aclimit4)
	c:RegisterEffect(e10)
	local e11=e8:Clone()
	e11:SetTargetRange(1,0)
	e11:SetCondition(s.econ2)
	c:RegisterEffect(e11)
end
s.material_setcode=0x9
function s.mfilter1(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp) and c:IsSetCard(0x9,fc,sumtype,tp)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_FIEND,fc,sumtype,tp) and c:GetLevel()>=10
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttackTarget()~=nil end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,bc:GetDefense())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	local atk=bc:GetAttack()
	local def=bc:GetDefense()
	if atk<0 then atk=0 end
	if def<0 then def=0 end
	Duel.Damage(1-tp,atk,REASON_EFFECT,true)
	Duel.Recover(tp,def,REASON_EFFECT,true)
	Duel.RDComplete()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
		and (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
function s.filter(c,e,tp)
	local z=e:GetHandler()
	return c:IsReason(REASON_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:GetReasonCard()==z
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():ResetFlagEffect(id)
end
function s.econ1(e)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.elimit(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.aclimit3(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
function s.aclimit4(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():ResetFlagEffect(id+1)
end
function s.econ2(e)
	return e:GetHandler():GetFlagEffect(id+1)~=0
end