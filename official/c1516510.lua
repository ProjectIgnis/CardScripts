--ルーンアイズ・ペンデュラム・ドラゴン
--Rune-Eyes Pendulum Dragon
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,16178681,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER))
	--multi attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
s.listed_names={16178681}
s.material_setcode={SET_ODD_EYES,SET_PENDULUM,SET_PENDULUM_DRAGON}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFusionSummoned()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=e:GetLabel()
	if (flag&0x3)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		if (flag&0x1)~=0 then
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetValue(1)
		else
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetValue(2)
		end
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if (flag&0x4)~=0 then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetValue(s.efilter)
		e4:SetOwnerPlayer(tp)
		e4:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e4)
	end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.lvfilter(c,fc)
	return c:IsCode(16178681) or c:CheckFusionSubstitute(fc)
end
function s.imfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsPendulumSummoned()
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	if #g==2 then
		local lv=0
		local lg1=g:Filter(s.lvfilter,nil,c)
		local lg2=g:Filter(Card.IsRace,nil,RACE_SPELLCASTER,c,SUMMON_TYPE_FUSION)
		if #lg1==2 then
			lv=lg2:GetFirst():GetOriginalLevel()
			local lc=lg2:GetNext()
			if lc then lv=math.max(lv,lc:GetOriginalLevel()) end
		else
			local lc=g:GetFirst()
			if lc==lg1:GetFirst() then lc=g:GetNext() end
			lv=lc:GetOriginalLevel()
		end
		if lv>4 then
			flag=0x2
		elseif lv>0 then
			flag=0x1
		end
	end
	if g:IsExists(s.imfilter,1,nil) then
		flag=flag+0x4
	end
	e:GetLabelObject():SetLabel(flag)
end