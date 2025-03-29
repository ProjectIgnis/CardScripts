--サイバーポッド
--Cyber Jar
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,PLAYER_ALL,LOCATION_DECK)
end
function s.spchk(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)
end
local function summon(g,e,p,tograve,ft)
	if #g==0 then return end
	if ft==0 then
		tograve:Merge(g)
		return
	end
	if ft<#g then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
		local newg=g:Select(p,ft,ft,nil)
		tograve:Merge(g:Sub(newg))
		g=newg
	end
	for tc in g:Iter() do
		Duel.SpecialSummonStep(tc,0,p,p,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	Duel.Destroy(g,REASON_EFFECT)
	Duel.BreakEffect()
	local p=Duel.GetTurnPlayer()
	local summonable1,nonsummonable1=Duel.GetDecktopGroup(p,5):Split(s.spchk,nil,e,p)
	local summonable2,nonsummonable2=Duel.GetDecktopGroup(1-p,5):Split(s.spchk,nil,e,1-p)
	local ft1=Duel.GetLocationCount(p,LOCATION_MZONE)
	if ft1>1 and Duel.IsPlayerAffectedByEffect(p,CARD_BLUEEYES_SPIRIT) and #summonable1>1 then
		nonsummonable1:Merge(summonable1)
		summonable1:Clear()
	end
	local ft2=Duel.GetLocationCount(1-p,LOCATION_MZONE)
	if ft2>1 and Duel.IsPlayerAffectedByEffect(1-p,CARD_BLUEEYES_SPIRIT) and #summonable2>1 then
		nonsummonable2:Merge(summonable2)
		summonable2:Clear()
	end
	local tohand,tograve=nonsummonable1:Merge(nonsummonable2):Split(Card.IsAbleToHand,nil)
	Duel.DisableShuffleCheck()
	Duel.ConfirmDecktop(p,5)
	summon(summonable1,e,p,tograve,ft1)
	Duel.ConfirmDecktop(1-p,5)
	summon(summonable2,e,1-p,tograve,ft2)
	Duel.SpecialSummonComplete()
	if #tohand>0 then
		Duel.SendtoHand(tohand,nil,REASON_EFFECT)
		Duel.ShuffleHand(tp)
		Duel.ShuffleHand(1-tp)
	end
	if #tograve>0 then
		Duel.SendtoGrave(tograve,REASON_EFFECT)
	end
	local fg=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.ShuffleSetCard(fg)
end