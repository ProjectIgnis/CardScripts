--プランキッズ・ミュー
--Prank-Kids Meow-Meow-Mu
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Level 4 or lower "Prank-Kids" monster
	Link.AddProcedure(c,s.mfilter,1,1)
	--Can only Link Summon "Prank-Kids Meow-Meow-Mu" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--Replace "Prank-Kids" monsters' Tribute cost
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(CARD_PRANKKIDS_MEOWMU)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.repcon)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x120}
function s.mfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x120,lc,sumtype,tp) and c:IsLevelBelow(4)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Cannot Link Summon "Prank-Kids Meow-Meow-Mu"
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK
end
function s.repcon(e)
	return e:GetHandler():IsAbleToRemoveAsCost()
end
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	local bp=e:GetHandlerPlayer()
	return Duel.IsTurnPlayer(1-bp) and c:IsSetCard(0x120) and c:IsLocation(LOCATION_MZONE) and c:IsControler(bp)
		and (not extracon or extracon(base,e,tp,eg,ep,ev,re,r,rp))
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Remove(base:GetHandler(),POS_FACEUP,REASON_COST+REASON_REPLACE)
end