--ＮＯ１３ エーテリック・アメン
--New Orders 13 Etheric Amon
local s,id=GetID()
function s.initial_effect(c)
	--Must be Special Summoned with a "Rank-Up-Magic" Spell, and cannot be Special Summoned by other ways.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function(e,se,sp,st) return se:GetHandler():IsSetCard(SET_RANK_UP_MAGIC) end)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle or card effects
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetValue(1)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2b)
	--Gains 100 ATK for each Xyz Material attached to it.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(function(e,c) return e:GetHandler():GetOverlayCount()*100 end)
	c:RegisterEffect(e3)
	--When this card is Special Summoned: Attach a number of cards from the top of your opponent's Deck to this card as Xyz Materials, equal to the difference in Ranks between this card and 1 face-up Xyz Monster your opponent controls.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(s.selfspoverlaytg)
	e4:SetOperation(s.selfspoverlayop)
	c:RegisterEffect(e4)
	--When exactly 1 Xyz Monster is Special Summoned to your opponent's side of the field: Attach a number of cards from the top of your opponent's Deck to this card as Xyz Materials, equal to the difference in Ranks between this card and that monster.
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.oppspattachcon)
	e5:SetTarget(s.oppspattachtg)
	e5:SetOperation(s.oppspattachop)
	c:RegisterEffect(e5)
end
function s.selfspoverlaytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.selfspoverlayop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsXyzMonster),tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsXyzMonster),tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	local attach_mats=c:GetRank()-tc:GetRank()
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<=attach_mats then
		attach_mats=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	end
	Duel.Overlay(c,Duel.GetDecktopGroup(1-tp,attach_mats))
end
function s.oppspattachfilter(c,tp)
	return c:IsFaceup() and c:IsXyzMonster() and c:IsControler(tp)
end
function s.oppspattachcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:IsExists(s.oppspattachfilter,1,nil,1-tp)
end
function s.oppspattachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg:GetFirst())
end
function s.oppspattachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local attach_mats=c:GetRank()-tc:GetRank()
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<=attach_mats then
		attach_mats=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	end
	Duel.Overlay(c,Duel.GetDecktopGroup(1-tp,attach_mats))
end
