--超装甲兵器ロボ ブラックアイアンＧ
--Super Armored Robot Armed Black Iron "C"
--Updated by DyXel
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand and equip any number of Insect monsters from your GY to it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Destroy all monsters your opponent controls with ATK greater than or equal to the ATK of the monster sent to the GY as the cost
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.eqfilter(c,e)
	return c:IsRace(RACE_INSECT) and c:IsCanBeEffectTarget(e) and not c:IsForbidden()
end
function s.rescon(g)
	return function(sg,e,tp,mg)
			return sg:GetClassCount(Card.GetCode)==1 and g:FilterCount(Card.IsCode,nil,sg:GetFirst():GetCode())==3
		end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc,e) end
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ft>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon(g),0)
	end
	ft=math.min(ft,3)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(g),1,tp,HINTMSG_EQUIP)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,tg,#tg,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local tg=Duel.GetTargetCards(e):Match(aux.NOT(Card.IsForbidden),nil)
	if #tg==0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft>0 and #tg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		tg=tg:Select(tp,ft,ft)
	end
	Duel.BreakEffect()
	for tc in tg:Iter() do
		if Duel.Equip(tp,tc,c,true,true) then
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
			--Equip limit
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(function(e,c) return e:GetOwner()==c end)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	Duel.EquipComplete()
end
function s.descostfilter(c,tp)
	return c:HasFlagEffect(id) and c:IsMonsterCard() and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackAbove,c:GetTextAttack()),tp,0,LOCATION_MZONE,1,nil)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local eqg=e:GetHandler():GetEquipGroup():Filter(s.descostfilter,nil,tp)
	if chk==0 then return #eqg>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=eqg:Select(tp,1,1,nil):GetFirst()
	e:SetLabel(tc:GetTextAttack())
	Duel.SendtoGrave(tc,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackAbove,e:GetLabel()),tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackAbove,e:GetLabel()),tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end