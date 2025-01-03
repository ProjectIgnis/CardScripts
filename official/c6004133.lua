--魔界劇団のゲネプロ
--Abyss Actors' Dress Rehearsal
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add Add 1 "Abyss Actor" card and 1 "Abyss Script" Spell to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ABYSS_ACTOR,SET_ABYSS_SCRIPT}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPhase(PHASE_MAIN1) and not Duel.CheckPhaseActivity()
end
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsSetCard(SET_ABYSS_ACTOR) or (c:IsSpell() and c:IsSetCard(SET_ABYSS_SCRIPT)))
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_ABYSS_ACTOR) and sg:IsExists(function(c) return c:IsSpell() and c:IsSetCard(SET_ABYSS_SCRIPT) end,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		return #g>1 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #rg>0 then
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,rg)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--Cannot Pendulum Summon for the rest of the turn, except "Abyss Actor" monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(SET_ABYSS_ACTOR) and aux.penlimit(e,se,sump,sumtype)
end