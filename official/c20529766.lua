--超電磁稼動ボルテック・ドラゴン
--Super-Electromagnetic Voltech Dragon
local s,id=GetID()
function s.initial_effect(c)
	--summon success
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--tribute check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	for tc in aux.Next(g) do
		local code=tc:GetCode()
		if code==55401221 then
			flag=flag|0x1
		elseif code==19733961 then
			flag=flag|0x2
		elseif code==63142001 then
			flag=flag|0x4
		end
	end
	e:GetLabelObject():SetLabel(flag)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE) and e:GetLabel()~=0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabel()
	local c=e:GetHandler()
	if flag&0x1~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(3682106)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e2)
	end
	if flag&0x2~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
	if flag&0x4~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if #g==1 and g:GetFirst()==e:GetHandler() then
		Duel.NegateEffect(ev)
	end
end
