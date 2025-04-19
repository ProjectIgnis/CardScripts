--Ｎｏ．４ 猛毒刺胞ステルス・クラーゲン (Anime)
--Number 4: Stealth Kragen (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 water monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),4,2)
	--Cannot be destroyed by battle with non-"Number" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--Destroy 1 face-up WATER monster on the field and damage controller
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Special Summon "Number 4: Stealth Kragen" and "Kragen Spawn" from your Extra Deck or GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Track its Xyz Materials on the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(s.matregop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	
end
s.listed_series={SET_NUMBER}
s.listed_names={67557908,94942656} --Number 4: Stealth Kragen, Kragen Spawn (OCG: Stealth Kragen Spawn)
s.xyz_number=4
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsAttribute(ATTRIBUTE_WATER) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,g:GetFirst():GetControler(),0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		if atk<=0 then atk=0 end
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.Damage(tc:GetControler(),atk,REASON_EFFECT)
		end
	end
end
function s.matregop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	g:KeepAlive()
	e:GetLabelObject():SetLabelObject(g)
end
function s.spfilter(c,e,tp)
	return c:IsCode(67557908,94942656) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(ect)
	return function(sg,e,tp,mg)
		return Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA) 
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
			and Duel.GetUsableMZoneCount(tp)>=#sg
			and (not ect or sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	local ct=#g
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,e:GetHandler(),e,tp)
	if chk==0 then return #sg>=ct and (not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or ct<=1) 
		and aux.SelectUnselectGroup(sg,e,tp,nil,nil,s.rescon(aux.CheckSummonGate(tp)),0) end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetTargetCards(e)
	local ct=#mg
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,e:GetHandler(),e,tp)
	if ct<=0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ct>1) or #g<ct then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,s.rescon(aux.CheckSummonGate(tp)),1,tp,HINTMSG_SPSUMMON)
	if #sg<=0 then return end
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		for oc in mg:Iter() do
			local tc=sg:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_MZONE):GetFirst()
			if not tc then break end
			Duel.Overlay(tc,oc)
			sg:RemoveCard(tc)
		end
	end
end