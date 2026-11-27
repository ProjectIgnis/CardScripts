--盟約のジャベリンビートル
--Javelin Beetle of the Alliance
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--During the Main Phase (Quick Effect): You can reveal this card in your hand; Ritual Summon 1 Insect Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level. You can only use this effect of "Javelin Beetle of the Alliance" once per Duel
	local ritual_params={
		handler=c,
		lvtype=RITPROC_GREATER,
		filter=function(c)
			return c:IsRace(RACE_INSECT)
		end
	}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsMainPhase()
	end)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(Ritual.Target(ritual_params))
	e1:SetOperation(Ritual.Operation(ritual_params))
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--If this card is Ritual Summoned: You can target 1 other card in this card's column; destroy it, and if you do, this card gains 600 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsRitualSummoned()
	end)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local colg=c:GetColumnGroup():Match(Card.IsCanBeEffectTarget,nil,e)
	if chkc then return colg:IsContains(chkc) and chkc~=c end
	if chk==0 then return #colg>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=colg:Select(tp,1,1,nil)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,600)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		--Destroy it, and if you do, this card gains 600 ATK
		c:UpdateAttack(600)
	end
end