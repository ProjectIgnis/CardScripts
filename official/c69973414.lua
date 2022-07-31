--ＢＦ－ツインシャドウ
--Blackwing - Twin Shadow
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_BLACK_WINGED_DRAGON}
s.listed_series={0x33}
function s.tdfilter(c)
	return c:IsSetCard(0x33) and c:HasLevel() and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp,lv)
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsType(TYPE_SYNCHRO) 
		and (c:IsSetCard(0x33) or c:IsCode(CARD_BLACK_WINGED_DRAGON))
		and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return #sg==2 and sg:FilterCount(Card.IsType,nil,TYPE_TUNER)==1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg:GetSum(Card.GetLevel))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,nil)
	if chk==0 then return #pg<=0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
	e:SetLabel(dg:GetSum(Card.GetLevel))
	Duel.ConfirmCards(1-tp,dg)
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end