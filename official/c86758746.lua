--アマゾネスの秘術
--Amazoness Secret Arts
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 "Amazoness" monster
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_AMAZONESS))
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Allow Fusion material from the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(s.fexop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_AMAZONESS}
function s.fexop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Extra Fusion Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetCountLimit(1)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_AMAZONESS) and c:IsAbleToGrave() end)
	e1:SetValue(s.matval)
	e1:SetLabelObject({s.extrafil_replacement})
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end
function s.matval(e,c)
	return c and c:IsSetCard(SET_AMAZONESS) and c:IsControler(e:GetHandlerPlayer())
end
function s.extrafil_repl_filter(c)
	return c:IsMonster() and c:IsAbleToGrave() and c:IsSetCard(SET_AMAZONESS)
end
function s.extrafil_replacement(e,tp,mg)
	local g=Duel.GetMatchingGroup(s.extrafil_repl_filter,tp,LOCATION_EXTRA,0,nil)
	return g,s.fcheck_replacement
end
function s.fcheck_replacement(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end