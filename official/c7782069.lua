--剛鬼ザ・タイラント・オーガ
--Gouki The Tyrant Ogre
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Gouki" Link Monster + 1 Warrior, Dinosaur, or Cyberse monster
	Fusion.AddProcMix(c,true,true,s.matfilter,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR|RACE_DINOSAUR|RACE_CYBERSE))
	--Register the Link Rating of the materials used for its Fusion Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Destroy cards on the field up to the total Link Rating of the "Gouki" Link Monsters used as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() and e:GetLabel()>0 end)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	e0:SetLabelObject(e1)
	--If this card battles, your opponent cannot activate cards or effects until the end of the Damage Step
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(function(e) return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler() end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GOUKI}
function s.matfilter(c)
	return c:IsSetCard(SET_GOUKI) and c:IsLinkMonster() 
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local total=g:Filter(Card.IsSetCard,nil,SET_GOUKI):GetSum(Card.GetLink)
	local link3=g:IsExists(Card.IsLinkAbove,1,nil,3) and 100 or 0
	e:GetLabelObject():SetLabel(total,link3)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local total,link3=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,total,nil)
	if link3==100 then
		Duel.SetChainLimit(function(te) return not Duel.GetTargetCards(e):IsContains(te:GetHandler()) end)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end