--The Wicked Dreadroot (Anime)
--邪神ドレッド・ルート
--マイケル・ローレンス・ディーによってスクリプト
--scripted by MLD
--credit to TPD & Cybercatman
--updated by Larry126
Duel.EnableUnofficialProc(PROC_DIVINE_HIERARCHY)
local s,id=GetID()
function s.initial_effect(c)
	--summon with 3 tribute
	local e0=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e1=aux.AddNormalSetProcedure(c,true,false,3,3)
	--half atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e3:SetValue(s.defval)
	c:RegisterEffect(e3)
end
-------------------------------------------------------------------
function s.atktg(e,c)
	return c~=e:GetHandler() and not c:IsRace(RACE_DIVINE)
end
function s.atkval(e,c)
	return c:GetAttack()/2
end
function s.defval(e,c)
	return c:GetDefense()/2
end