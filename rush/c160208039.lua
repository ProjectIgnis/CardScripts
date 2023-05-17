--幻壊爆僚ワーニング・ヘビー・ショック
--Demolition Charge Expert Warning Heavy Shock
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160208046,160208043)
	--Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.thfilter(c)
	return (c:IsCode(CARD_FUSION) or (s.thfilter2(c))) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsMonster() and c:IsRace(RACE_WYRM) and c:IsLevelAbove(8)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--gy recover
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	if #sg>0 then
		Duel.BreakEffect()
		local tg=aux.SelectUnselectGroup(sg,1,tp,1,ft,s.rescon,1,tp)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
		local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil)
		if #dg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=dg:Select(tp,1,1,nil)
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg,true)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,CARD_FUSION)<2 and sg:FilterCount(s.thfilter2,nil)<2
end