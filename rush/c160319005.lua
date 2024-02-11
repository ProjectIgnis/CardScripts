--ロード・オブ・ドラゴン－ドラゴンの絶対者
--Absolute Lord of D.
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top 4 cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160319027} --The Ultimate Blue-Eyed Legend
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN|STATUS_SPSUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	Duel.ConfirmDecktop(tp,4)
	local g=Duel.GetDecktopGroup(tp,4)
	Duel.DisableShuffleCheck()
	local sg=g:Filter(s.sfilter,nil)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=aux.SelectUnselectGroup(sg,1,tp,1,2,s.rescon,1,tp)
		if #tg>0 then
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tg)
			Duel.ShuffleHand(tp)
			g:RemoveCard(tg)
		end
	end
	if #g>0 then
		Duel.ShuffleDeck(tp)
	end
end
function s.sfilter(c)
	return (c:IsCode(160319027) or s.sfilter2(c)) and c:IsAbleToHand()
end
function s.sfilter2(c)
	return c:IsMonster() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(8)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,160319027)<2 and sg:FilterCount(s.sfilter2,nil)<2
end