--暗黒神殿ザララーム
--Zararham the Dark Temple
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--No Activations during BP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.actcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Burn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.bcon)
	e3:SetTarget(s.btg)
	e3:SetOperation(s.bop)
	c:RegisterEffect(e3)
	--Search a Field Spell
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_names={TOKEN_BRAVE,100417030,id}
--No Activations during BP
function s.eqfilter(c)
	return c:GetEquipGroup():IsExists(Card.IsCode,1,nil,100417030)
end
function s.actcon(e)
	return Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(s.eqfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--Burn
function s.bcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsControler(tp) and rc:IsCode(TOKEN_BRAVE)
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=eg:GetFirst():GetBattleTarget():GetTextAttack()
	if chk==0 then return atk>0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,atk,1-tp,0)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Damage(1-tp,eg:GetFirst():GetBattleTarget():GetTextAttack(),REASON_EFFECT)
end
--Search a Field Spell
function s.thcon(e,tp,eg,ep,ev,re,r,rp) 
	return Duel.GetFlagEffect(tp,id)>0
end
function s.thfilter(c)
	return aux.IsCodeListed(c,TOKEN_BRAVE) and c:IsType(TYPE_SPELL)
		and c:IsType(TYPE_FIELD) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end