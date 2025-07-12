--ギャラクシーアイズ ＦＡ・フォトン・ドラゴン
--Galaxy-Eyes Full Armor Photon Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 8 monsters OR 1 "Galaxy-Eyes" Xyz Monster you control, except "Galaxy-Eyes Full Armor Photon Dragon"
	Xyz.AddProcedure(c,nil,8,3,s.ovfilter,aux.Stringid(id,0))
	--Attach up to 2 Equip Cards equipped to this card to this card as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.HintSelectedEffect)
	e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	c:RegisterEffect(e1)
	--Destroy 1 face-up card your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.AND(Cost.DetachFromSelf(1),Cost.HintSelectedEffect))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_GALAXY_EYES}
function s.ovfilter(c,tp,xyzc)
	return c:IsSetCard(SET_GALAXY_EYES,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and not c:IsSummonCode(xyzc,SUMMON_TYPE_XYZ,tp,id) and c:IsFaceup()
end
function s.attachfilter(c,xyzc,e,tp)
	return c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT) and c:IsCanBeEffectTarget(e)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup()
	if chkc then return eqg:IsContains(chkc) and s.attachfilter(chkc,c,e,tp) end
	if chk==0 then return eqg:IsExists(s.attachfilter,1,nil,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=eqg:FilterSelect(tp,s.attachfilter,1,2,nil,c,e,tp)
	Duel.SetTargetCard(tg)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
	if #tg>0 then
		Duel.Overlay(c,tg)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
