--D－HERO ディパーテッドガイ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--redirect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.recon)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	if departchk==nil then departchk=0 departchktable={} else departchk=departchk+1 end
	departchktable[departchk]={} departchktable[departchk][-1]={} 
	departchktable[departchk][0]=0 departchktable[departchk][-1][0]=0
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_CHAINING)
	ge1:SetLabel(departchk)
	ge1:SetLabelObject(e1)
	ge1:SetOperation(s.checkop)
	Duel.RegisterEffect(ge1,0)
	e1:SetLabel(departchk)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if tp~=Duel.GetTurnPlayer() then return false end
	local num=e:GetLabel()
	if departchktable[num][0]~=departchktable[num][-1][0] or departchktable[num][1]==nil then return true end
	for i=1,departchktable[num][0] do
		if departchktable[num][i]~=departchktable[num][-1][i] then return true end
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
function s.recon(e)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE))
		or (c:IsLocation(LOCATION_DECK+LOCATION_HAND) and c:IsReason(REASON_EFFECT))
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local num=e:GetLabel()
	if re==e:GetLabelObject() then
		if departchktable[num][1]==nil then
			departchktable[num][1]=re
			departchktable[num][0]=1
		else
			for i=1,departchktable[num][0] do
				departchktable[num][-1][i]=departchktable[num][i]
			end
			departchktable[num][1]=re
			departchktable[num][-1][0]=departchktable[num][0]
			departchktable[num][0]=1
		end
	else
		if not re:IsHasType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_QUICK_F) then
			for i=1,departchktable[num][0] do
				departchktable[num][-1][i]=nil
				departchktable[num][i]=nil
			end
			departchktable[num][-1][0]=0
			departchktable[num][0]=0
		elseif departchktable[num][0]>0 then
			departchktable[num][0]=departchktable[num][0]+1
			departchktable[num][departchktable[num][0]]=re
		end
	end
end
