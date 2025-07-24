--古生代化石竜 スカルギオス
--Fossil Dragon Skullgios
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 Rock monster + 1 Level 7 or higher monster in your opponent's GY
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ROCK),s.matfilter)
	--"Clock Lizard" check
	Auxiliary.addLizardCheck(c)
	--Must be Special Summoned with "Fossil Fusion"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.FossilLimit)
	c:RegisterEffect(e0)
	--Switch the current ATK and DEF of that opponent's monster this card is battling until the end of that Damage Step
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(s.switchcon)
	e1:SetOperation(s.switchop)
	c:RegisterEffect(e1)
	--If this card attacks a Defense Position monster, inflict piercing battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--If this Fusion Summoned card battles an opponent's monster, any battle damage it inflicts to your opponent is doubled
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(s.doubledamcon)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
end
s.listed_names={CARD_FOSSIL_FUSION}
function s.matfilter(c,sc,st,tp)
	return c:IsLevelAbove(7) and c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE)
end
function s.switchcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsRelateToBattle() and bc:HasDefense() and not bc:IsAttack(bc:GetDefense()) and bc:IsControler(1-tp)
end
function s.switchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		local atk=bc:GetAttack()
		local def=bc:GetDefense()
		--Switch the current ATK and DEF of that opponent's monster until the end of that Damage Step
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SWAP_ATTACK_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SWAP_DEFENSE_FINAL)
		e2:SetValue(atk)
		bc:RegisterEffect(e2)
	end
end
function s.doubledamcon(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsFusionSummoned() and bc and bc:IsControler(1-e:GetHandlerPlayer())
end