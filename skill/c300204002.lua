--Knight of Legend
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={6368038} --"Gaia the Fierce Knight"
s.listed_series={SET_GAIA_THE_FIERCE_KNIGHT,0x580} --"Gaia the Dragon Champion" archetype
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--OPD check to prevent hint from occuring
	if Duel.GetFlagEffect(tp,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD register to prevent hint from occuring
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Each turn, 1 "Gaia the Fierce Knight" you control can be Normal Summoned without Tributing
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ntcon)
	e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
	Duel.RegisterEffect(e1,tp)
	--You cannot activate Set cards in the Spell & Trap Zones
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.effilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	e2:SetTarget(function(e,c) return c:IsFacedown() end)
	Duel.RegisterEffect(e2,tp)
	--If a "Gaia the Fierce Knight" monster or "Gaia the Dragon Champion" monster you control inflicts piercing damage, draw 2 cards then discard 1
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	Duel.RegisterEffect(e3,tp)
	--Inflict piercing damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_PIERCE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GAIA_THE_FIERCE_KNIGHT))
	Duel.RegisterEffect(e4,tp)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_PIERCE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x580))
	Duel.RegisterEffect(e5,tp)
end
--Normal Summon with no Tribute functions
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsCode(6368038)
end
--Draw/Discard functions
function s.effilter(c)
	return c:IsFaceup() and (c:IsSetCard(SET_GAIA_THE_FIERCE_KNIGHT) or c:IsGaiatheDragonChampion())
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsControler(tp) and bc and bc:IsDefensePos() and (tc:IsSetCard(SET_GAIA_THE_FIERCE_KNIGHT) or tc:IsGaiatheDragonChampion())
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	end
end
