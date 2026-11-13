--真青眼の超究極竜
--Neo Blue-Eyes Hyper Ultimate Dragon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Blue-Eyes White Dragon" + 2 monsters that are "Blue-Eyes White Dragon" and/or mention "Endless Darkness"
	Fusion.AddProcMixN(c,true,true,CARD_BLUEEYES_W_DRAGON,1,s.matfilter,2)
	--Can make up to 3 attacks on monsters during each Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(2)
	c:RegisterEffect(e1)
	--During your Main Phase: You can Set 1 Spell/Trap that mentions "Endless Darkness" from your Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SET+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--When your opponent activates a monster effect on the field (Quick Effect): You can banish that monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON,CARD_ENDLESS_DARKNESS}
function s.matfilter(c,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,CARD_BLUEEYES_W_DRAGON) or c:ListsCode(CARD_ENDLESS_DARKNESS)
end
function s.setfilter(c)
	return c:ListsCode(CARD_ENDLESS_DARKNESS) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and re:IsCardLocation(LOCATION_MZONE) and re:GetHandler():IsRelateToEffect(re)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsAbleToRemove() end
	rc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(e) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end