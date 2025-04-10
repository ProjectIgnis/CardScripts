--D－HERO ディパーテッドガイ
--Destiny HERO - Departed
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Banish when destroyed by battle or sent to the GY from the Deck or Hand by an effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.redirectval)
	c:RegisterEffect(e2)
	--Infinite loop prevention when only forced triggers are into play (Slifer the Sky Dragon, King Tiger Wanghu, etc.)
	local departchktable={}
	departchktable[-1]={}
	departchktable[0]=0
	departchktable[-1][0]=0
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_CHAINING)
	ge1:SetLabelObject({e1,departchktable})
	ge1:SetOperation(s.checkop)
	Duel.RegisterEffect(ge1,0)
	e1:SetLabelObject(departchktable)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsTurnPlayer(tp) then return false end
	local departchktable=e:GetLabelObject()
	if departchktable[0]~=departchktable[-1][0] or departchktable[1]==nil then return true end
	for i=1,departchktable[0] do
		if departchktable[i]~=departchktable[-1][i] then return true end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
end
function s.redirectval(e,c,reason)
	local c=e:GetHandler()
	if (c:IsLocation(LOCATION_MZONE) and (reason&REASON_BATTLE)==REASON_BATTLE) or
		(c:IsLocation(LOCATION_DECK|LOCATION_HAND) and (reason&REASON_EFFECT)==REASON_EFFECT) then
		return LOCATION_REMOVED
	end
	return 0
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local labelEff,departchktable=table.unpack(e:GetLabelObject())
	if re==labelEff then
		if departchktable[1]==nil then
			departchktable[1]=re
			departchktable[0]=1
		else
			for i=1,departchktable[0] do
				departchktable[-1][i]=departchktable[i]
			end
			departchktable[1]=re
			departchktable[-1][0]=departchktable[0]
			departchktable[0]=1
		end
	else
		if not re:IsHasType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_QUICK_F) then
			for i=1,departchktable[0] do
				departchktable[-1][i]=nil
				departchktable[i]=nil
			end
			departchktable[-1][0]=0
			departchktable[0]=0
		elseif departchktable[0]>0 then
			departchktable[0]=departchktable[0]+1
			departchktable[departchktable[0]]=re
		end
	end
end