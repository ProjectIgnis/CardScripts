--Ｅ－ＨＥＲＯ マリシャス・デビル
--Evil HERO Malicious Fiend
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,58554959,s.ffilter)
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Monsters must attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.poscon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(s.atklimit)
	c:RegisterEffect(e3)
end
s.material_setcode={SET_HERO,SET_EVIL_HERO}
s.dark_calling=true
s.listed_names={CARD_DARK_FUSION,58554959,CARD_SUPER_POLYMERIZATION}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_FIEND,fc,sumtype,tp) and c:GetLevel()>=6
end
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(CARD_DARK_FUSION,CARD_SUPER_POLYMERIZATION)
end
function s.poscon(e)
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer() and Duel.IsBattlePhase()
end
function s.atklimit(e,c)
	return c==e:GetHandler()
end