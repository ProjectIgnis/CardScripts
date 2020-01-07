--Hane-Hane (DOR)
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--return to deck
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_TODECK)
e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e1:SetTarget(s.target)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chkc then return chkc:GetLocation()==LOCATION_MZONE and chkc:IsAbleToDeck() end
if chk==0 then return true end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local tc=e:GetHandler()
if tc and tc:IsRelateToEffect(e) then
Duel.SendtoDeck(e:GetHandler(),tp,POS_FACEDOWN,REASON_EFFECT)
end
end
