--宝玉の双璧 (Anime)
--Crystal Pair (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Crystal Beast" monster from your Deck in your Spell & Trap Card Zone, face-up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.plcon)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CRYSTAL_BEAST}
function s.confilter(c,tp)
	return c:IsPreviousSetCard(SET_CRYSTAL_BEAST) and c:IsPreviousControler(tp)
end
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confilter,1,nil,tp)
end
function s.plfilter(c)
	return c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsMonster() and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	--You take no battle damage for the rest of this turn 
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end