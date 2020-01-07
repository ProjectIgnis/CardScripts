--Wonderbeat Elf
--scripted by:urielkama
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--must attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetCondition(s.facon)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end
function s.facon(e)
	return e:GetHandler():GetAttackableTarget():GetCount()>0
end
function s.filter(c)
	return c:IsFaceup() and c:IsElf()
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
end
