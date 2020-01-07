--海晶乙女の闘海
--Marincess Battle Ocean
--scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk1
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x12b))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	--atk2
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.atktg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--immune
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(alias,0))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.etarget)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	--equip
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(alias,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(s.condition)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
	aux.GlobalCheck(s,function()
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MATERIAL_CHECK)
		e1:SetValue(s.matchk)
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		ge1:SetLabelObject(e1)
		ge1:SetTargetRange(0xff,0xff)
		Duel.RegisterEffect(ge1,0)
	end
	)
end
s.listed_series={0x12b}
s.listed_names={101010040}
function s.matchk(e,c)
	if c:GetMaterial():IsExists(Card.IsLinkCode,1,nil,101010040) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TEMP_REMOVE,0,1)
	end
end
function s.atkfilter(c)
	return c:GetOriginalType()&(TYPE_LINK+TYPE_MONSTER)==(TYPE_LINK+TYPE_MONSTER) and c:IsSetCard(0x12b)
end
function s.atktg(e,c)
	return c:GetEquipGroup():IsExists(s.atkfilter,1,nil)
end
function s.atkval(e,c)
	return c:GetEquipGroup():Filter(s.atkfilter,nil):GetSum(Card.GetLink)*300
end
function s.etarget(e,c)
	return c:IsFaceup() and c:GetFlagEffect(id)~=0 and c:IsSetCard(0x12b) and c:IsLinkMonster() and c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkMonster() and c:GetSequence()>4
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.eqfilter(c)
	return c:IsSetCard(0x12b) and c:IsLinkMonster() and not c:IsForbidden()
end
function s.eqcon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLink)==#sg
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.cfilter(chkc) end
	if chk==0 then return eg:IsExists(s.cfilter,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=eg:FilterSelect(tp,s.cfilter,1,1,nil)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local tc=Duel.GetFirstTarget()
	if ft<1 or not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local g=aux.SelectUnselectGroup(Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,nil),e,tp,1,math.min(ft,3),s.eqcon,1,tp,HINTMSG_EQUIP)
	for eqc in aux.Next(g) do
		Duel.Equip(tp,eqc,tc,true,true)
		--Equip limit
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		eqc:RegisterEffect(e1,true)
	end
	Duel.EquipComplete()
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
