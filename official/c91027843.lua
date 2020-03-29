--海晶乙女の闘海
--Marincess Battle Ocean
--Scripted by Eerie Code, based on Larry126's anime version
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x12b))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.etarget)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--equip
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.eqcon)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
	--material check
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
	end)
end
s.listed_names={67712104}
s.listed_series={0x12b}
function s.matchk(e,c)
	if c:GetMaterial():IsExists(Card.IsCode,1,nil,67712104) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TEMP_REMOVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	end
end
function s.atkval(e,c)
	return 200+c:GetEquipGroup():FilterCount(Card.IsSetCard,nil,0x12b)*600
end
function s.etarget(e,c)
	return c:IsFaceup() and c:GetSequence()>=5 and c:GetFlagEffect(id)~=0 and c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.eqcfilter(c,tp)
	return c:IsSetCard(0x12b) and c:IsLinkMonster() and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetSequence()>=5 and c:IsSummonPlayer(tp)
end
function s.eqfilter(c)
	return c:IsSetCard(0x12b) and c:IsLinkMonster() and not c:IsForbidden()
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqcfilter,1,nil,tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local tc=eg:Filter(s.eqcfilter,nil,tp):GetFirst()
	if ft<1 or not tc or not tc:IsFaceup() then return end
	local g=aux.SelectUnselectGroup(Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,nil),e,tp,1,math.min(ft,3),aux.dncheck,1,tp,HINTMSG_EQUIP)
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
