--Japanese name
--Vortex of Time
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent activates a Normal or Quick-Play Spell Card or effect, or a monster effect, while you control a Zombie monster and "Call of the Haunted" (except during the Damage Step): Your opponent tosses a coin and their activated effect becomes the following effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.changecon)
	e1:SetTarget(s.changetg)
	e1:SetOperation(s.changeop)
	c:RegisterEffect(e1)
end
s.toss_coin=true
s.listed_names={CARD_CALL_OF_THE_HAUNTED}
function s.changecon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and (re:IsMonsterEffect() or (re:IsSpellEffect() and (rc:IsNormalSpell() or rc:IsQuickPlaySpell())))
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_ZOMBIE),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_CALL_OF_THE_HAUNTED),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.changetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,1-tp,1)
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	local coin=Duel.TossCoin(1-tp,1)
	if coin==COIN_HEADS then
		--● Heads: "Your opponent must banish 1 monster they control"
		Duel.ChangeChainOperation(ev,s.repop1)
	elseif coin==COIN_TAILS then
		--● Tails: "You must banish all monsters you control"
		Duel.ChangeChainOperation(ev,s.repop2)
	end
end
function s.repop1(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(opp,Card.IsAbleToRemove,opp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_RULE,PLAYER_NONE,opp)
	end
end
function s.repop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_RULE)
	end
end