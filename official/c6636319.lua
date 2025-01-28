--Ｅｖｉｌ★Ｔｗｉｎ キスキル・ディール
--Evil★Twin Ki-sikil Deal
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 1 "Ki-Sikil" monster
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_KI_SIKIL),1,1)
	--You can only Link Summon "Evil★Twin Ki-sikil Deal" once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--Apply this effect for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return not Duel.HasFlagEffect(tp,id) end)
	e1:SetCost(s.effcost)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_KI_SIKIL,SET_LIL_LA}
s.listed_names={id}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Prevent another Link Summon of "Evil★Twin Ki-sikil Deal" that turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.costfilter(c)
	return c:IsSetCard(SET_LIL_LA) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local c=e:GetHandler()
	--Draw 1 card immediately after it resolves
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetCondition(s.drawcon)
	e1:SetOperation(s.drawop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,1))
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	local chainlink=Duel.GetCurrentChain(true)-1
	if not (chainlink>0 and ep==1-tp) then return false end
	local trig_p,trig_typ,setcodes=Duel.GetChainInfo(chainlink,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_SETCODES)
	if not (trig_p==tp and (trig_typ&TYPE_MONSTER)>0) then return false end
	for _,set in ipairs(setcodes) do
		if ((SET_KI_SIKIL&0xfff)==(set&0xfff) and (SET_KI_SIKIL&set)==SET_KI_SIKIL)
		or ((SET_LIL_LA&0xfff)==(set&0xfff) and (SET_LIL_LA&set)==SET_LIL_LA) then
			return true
		end
	end
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.Draw(tp,1,REASON_EFFECT)
end