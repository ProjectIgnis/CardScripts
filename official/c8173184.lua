--リペア・ジェネクス・コントローラー
--Repair Genex Controller
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Level 4 or lower "Genex" Monster
	Link.AddProcedure(c,s.matfilter,1,1)
	--Can only Special Summon "Repaired Genex Controller" once per turn
	c:SetSPSummonOnce(id)
	--Add 1 "Genex" monster from the GY to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Normal Summon 1 "Genex" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(function(_,tp,eg) return eg:IsExists(s.nsconfilter,1,nil,tp) end)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GENEX}
s.listed_names={id}
function s.matfilter(c,sc,st,tp)
	return c:IsSetCard(SET_GENEX,sc,st,tp) and c:IsLevelBelow(4)
end
function s.thfilter(c)
	return c:IsSetCard(SET_GENEX) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.nsconfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(SET_GENEX) and not c:IsReason(REASON_DRAW)
end
function s.nsfilter(c)
	return c:IsSetCard(SET_GENEX) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except by Synchro Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_e,_c,_tp,st,pos,target_p,sumeff,proc_eff) return _c:IsLocation(LOCATION_EXTRA) and (st&SUMMON_TYPE_SYNCHRO~=SUMMON_TYPE_SYNCHRO or proc_eff==nil) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard Check
	aux.addTempLizardCheck(c,tp,aux.TRUE)
	--Must use at least 1 "Genex" Tuner to Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetTargetRange(LOCATION_MZONE|LOCATION_HAND,0)
	e2:SetTarget(function(_,_c) return not (_c:IsSetCard(SET_GENEX) and _c:IsType(TYPE_TUNER)) end)
	e2:SetOperation(s.synop)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.gtfilter(c,sc,tp)
	return c:IsSetCard(SET_GENEX,sc,SUMMON_TYPE_SYNCHRO,tp) and c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO,tp)
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	return e:GetHandlerPlayer()==1-tp or tg:IsExists(Card.IsSetCard,1,nil,SET_GENEX,sc,SUMMON_TYPE_SYNCHRO,tp) or ntg:IsExists(s.gtfilter,1,nil,sc,tp)
end