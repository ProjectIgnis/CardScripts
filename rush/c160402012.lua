-- ハンズレイ・デストライオ
-- Handsray Destleo
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Send 2 random cards from opponent's hand to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local ct=#g==1 and 1 or Duel.AnnounceNumberRange(tp,1,2)
	local sg=g:RandomSelect(tp,ct)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
