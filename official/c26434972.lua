--刻まれし魔の憐歌
--Fiendsmith Kyrie
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Your LIGHT Fiend monsters cannot be destroyed by battle, also any battle damage you take is halved
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return not Duel.HasFlagEffect(tp,id) end end)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Fusion Summon 1 "Fiendsmith" Fusion Monster from your Extra Deck, using monsters you control and/or monsters in your Spell & Trap Zone that are equipped to a "Fiendsmith" monster as material
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_FIENDSMITH),matfilter=Fusion.OnFieldMat,extrafil=s.extramat}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)
end
s.listed_series={SET_FIENDSMITH}
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local c=e:GetHandler()
	--This turn, your LIGHT Fiend monsters cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND) end)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
	--This turn, any battle damage you take is halved
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetTargetRange(1,0)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.extramatfilter(c)
	local ec=c:GetEquipTarget()
	return c:IsMonsterCard() and c:IsFaceup() and ec and ec:IsSetCard(SET_FIENDSMITH)
end
function s.extramat(e,tp,mg)
	return Duel.GetMatchingGroup(s.extramatfilter,tp,LOCATION_STZONE,0,nil)
end