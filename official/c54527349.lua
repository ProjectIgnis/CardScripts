--叛逆の堕天使
--Darklord Uprising
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DARKLORD}
function s.fextra(exc)
	return function(e,tp,mg)
		return nil,s.costcardcheck(exc)
	end
end
function s.costcardcheck(exc)
	return function(tp,sg,fc)
		return not (exc and sg:IsContains(exc))
	end
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(SET_DARKLORD) and c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()) then return false end
	local params={fusfilter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),extrafil=s.fextra(c)}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local params={fusfilter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK)}
		return e:GetLabel()==100 or Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	end
	local cost_card=e:GetLabelObject()
	if cost_card then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,cost_card:GetBaseAttack())
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local cost_card=e:GetLabelObject()
	local params={}
	if cost_card then
		params={fusfilter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),extrafil=s.fextra(cost_card),stage2=s.stage2}
	else
		params={fusfilter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK)}
	end
	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp,1)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetLabelObject() then
		local lp=e:GetLabelObject():GetAttack()
		if lp>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Recover(tp,lp,REASON_EFFECT)
		end
		e:SetLabelObject(nil)
	end
end