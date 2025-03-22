--プランキッズ・ミュー
--Prank-Kids Meow-Meow-Mu
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 1 Level 4 or lower "Prank-Kids" monster
	Link.AddProcedure(c,s.matfilter,1,1)
	--You can only Link Summon "Prank-Kids Meow-Meow-Mu" once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--If a "Prank-Kids" monster you control would Tribute itself to activate its effect during your opponent's turn, you can banish this card you control or from your GY instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(CARD_PRANKKIDS_MEOWMU)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsAbleToRemoveAsCost() end)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PRANK_KIDS}
s.listed_names={id}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_PRANK_KIDS,lc,sumtype,tp) and c:IsLevelBelow(4)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--You cannot Link Summon "Prank-Kids Meow-Meow-Mu" for the rest of this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se) return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return Duel.IsTurnPlayer(1-tp) and c:IsSetCard(SET_PRANK_KIDS) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and (extracon==nil or extracon(base,e,tp,eg,ep,ev,re,r,rp))
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Remove(base:GetHandler(),POS_FACEUP,REASON_COST|REASON_REPLACE)
end