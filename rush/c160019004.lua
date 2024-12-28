--ヴォルカライズ・イフリート
--Volcalize Ifrit
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Tribute check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	--Gain ATK equal to the ATK of 1 monster tributed for its Tribute Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetOperation(s.facechk)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
function s.valcheck(e,c)
	local tc=c:GetMaterial():GetFirst()
	local atk=0
	if tc and tc:IsAttribute(ATTRIBUTE_FIRE) and tc:IsRace(RACE_PYRO|RACE_AQUA|RACE_THUNDER) then atk=tc:GetOriginalLevel()*400 end
	if atk<0 then atk=0 end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
end
function s.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end