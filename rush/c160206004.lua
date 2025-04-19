--合成魔獣 ガーゼット
--Maju Garzett (Rush)
local s,id=GetID()
function s.initial_effect(c)
	--tribute check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	--Gain ATK when it is Tribute Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetOperation(s.facechk)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	if #g==1 and (tc:HasFlagEffect(FLAG_DOUBLE_TRIB) or tc:HasFlagEffect(FLAG_DOUBLE_TRIB_DARK+FLAG_DOUBLE_TRIB_FIEND+FLAG_DOUBLE_TRIB_0_ATK+FLAG_DOUBLE_TRIB_0_DEF+FLAG_DOUBLE_TRIB_EFFECT)) then
		atk=tc:GetTextAttack()*2
		if tc:IsMaximumMode() then
			atk=tc.MaximumAttack*2
		end
	else
		for tc in g:Iter() do
			local catk=tc:GetTextAttack()
			if tc:IsMaximumMode() then
				catk=tc.MaximumAttack*2
			end
			atk=atk+(catk>=0 and catk or 0)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
end
function s.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end