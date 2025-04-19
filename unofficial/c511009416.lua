--ジャンク・ウォリアー (Anime)
--Junk Warrior (Anime)
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.con)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
end
s.material={63977008}
s.listed_names={63977008}
s.material_setcode=0x1017
function s.tfilter(c,scard,sumtype,tp)
	return c:IsSummonCode(scard,sumtype,tp,63977008) or c:IsHasEffect(20932152)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSynchroSummoned()
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(2)
end
function s.value(e,c)
	return Duel.GetMatchingGroup(s.filter,c:GetControler(),LOCATION_MZONE,0,c):GetSum(Card.GetAttack)
end