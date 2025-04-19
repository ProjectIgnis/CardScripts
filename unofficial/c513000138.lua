--The Wicked Avatar (Anime)
--邪神アバター
--マイケル・ローレンス・ディーによってスクリプト
--scripted by MLD
--credit to TPD & Cybercatman
--updated by Larry126
Duel.EnableUnofficialProc(PROC_DIVINE_HIERARCHY)
local s,id=GetID()
function s.initial_effect(c)
	--summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e2=aux.AddNormalSetProcedure(c,true,false,3,3)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_REPEAT+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.adval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
	c:RegisterEffect(e4)
	--atk check
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(21208154)
	c:RegisterEffect(e5)
end
-------------------------------------------------------------------
function s.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(21208154)
end
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(s.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then
		return 1
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		if val>=9999999 then
			return val
		else
			return val+1
		end
	end
end