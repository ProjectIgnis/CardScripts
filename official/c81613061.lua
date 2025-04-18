--ウォークライ・ミーディアム
--War Rock Medium
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Cannot activate monster effects on the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(s.limcon)
	e2:SetValue(s.limval)
	c:RegisterEffect(e2)
	--Set 1 "War Rock" Spell/Trap from your Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_WAR_ROCK}
s.listed_names={id}
function s.wrfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsSetCard(SET_WAR_ROCK)
end
function s.limcon(e)
	return Duel.IsPhase(PHASE_MAIN1)
		and Duel.IsExistingMatchingCard(s.wrfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsSummonType,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL)
end
function s.limval(e,re,tp)
	return re:GetActivateLocation()==LOCATION_MZONE and re:IsMonsterEffect()
end
function s.setfilter(c)
	return c:IsSetCard(SET_WAR_ROCK) and not c:IsCode(id) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
	--Cannot Special Summon, except Warrior monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsRace(RACE_WARRIOR) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end