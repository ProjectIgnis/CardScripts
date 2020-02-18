--ジ・アライバル・サイバース＠イグニスター (Anime)
--The Arrival Cyberse @Ignister (Anime)
--Scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	c:EnableCounterPermit(0x135)
	c:SetCounterLimit(0x135,1)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttackAbove,1500),2,nil,s.lcheck)
	--summmon success
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--add counter
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32750510,0))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	--immune
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.econ)
	e4:SetValue(s.efilter1)
	c:RegisterEffect(e4)
	--use counter
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(38572779,0))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON)
	e5:SetCountLimit(1)
	e5:SetCost(s.imcost)
	e5:SetTarget(s.imtg)
	e5:SetOperation(s.imop)
	c:RegisterEffect(e5)
	--destroy
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(alias,0))
	e6:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.destg)
	e6:SetOperation(s.desop)
	c:RegisterEffect(e6)
end
s.listed_names={alias}
function s.lcheck(g,lc,tp)
	return g:GetClassCount(Card.GetAttribute)==#g
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_LINK) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaterialCount()*1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)*1000
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x135,1) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,e:GetHandler(),1,LOCATION_MZONE,0x135)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x135,1)
	end
end
function s.econ(e)
	return e:GetHandler():GetCounter(0x135)>0
end
function s.efilter1(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.imcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x135,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x135,1,REASON_COST)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.imtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.efilter2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end
function s.efilter2(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=e:GetHandler() end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,c:GetLinkedZone())>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,alias+1,0x135,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,e:GetHandler():GetLinkedZone())>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,alias+1,0x135,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,alias+1)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP,e:GetHandler():GetLinkedZone())
	end
end
